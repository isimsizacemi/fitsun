lkmalı ?const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin
const serviceAccount = {
    type: "service_account",
    project_id: process.env.FIREBASE_PROJECT_ID || "fitsun-app",
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID || "dummy_key_id",
    private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n') || "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7VJTUt9Us8cKB\n-----END PRIVATE KEY-----\n",
    client_email: process.env.FIREBASE_CLIENT_EMAIL || "firebase-adminsdk-dummy@fitsun-app.iam.gserviceaccount.com",
    client_id: process.env.FIREBASE_CLIENT_ID || "dummy_client_id",
    auth_uri: "https://accounts.google.com/o/oauth2/auth",
    token_uri: "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${process.env.FIREBASE_CLIENT_EMAIL || "firebase-adminsdk-dummy@fitsun-app.iam.gserviceaccount.com"}`
};

try {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: process.env.FIREBASE_PROJECT_ID || "fitsun-app"
    });
    console.log('Firebase Admin initialized successfully');
} catch (error) {
    console.log('Firebase Admin initialization failed:', error.message);
    console.log('Continuing without Firebase Admin (development mode)');
}

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || 'YOUR_GEMINI_API_KEY');

// Routes
app.get('/', (req, res) => {
    res.json({
        message: 'FitSun Backend API',
        status: 'running',
        version: '1.0.0'
    });
});

// Generate workout program endpoint
app.post('/api/generate-workout', async (req, res) => {
    try {
        const { userId, userProfile } = req.body;

        if (!userProfile) {
            return res.status(400).json({
                error: 'User profile is required'
            });
        }

        // Create prompt for Gemini
        const prompt = createWorkoutPrompt(userProfile);

        // Generate workout program using Gemini
        const model = genAI.getGenerativeModel({ model: "gemini-pro" });
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();

        // Parse the JSON response
        let workoutProgram;
        try {
            // Extract JSON from the response (remove any markdown formatting)
            const jsonMatch = text.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                workoutProgram = JSON.parse(jsonMatch[0]);
            } else {
                throw new Error('No JSON found in response');
            }
        } catch (parseError) {
            console.error('Error parsing Gemini response:', parseError);
            console.error('Raw response:', text);

            // Return a fallback workout program
            workoutProgram = createFallbackWorkout(userProfile);
        }

        // Add metadata
        workoutProgram.userId = userId;
        workoutProgram.createdAt = new Date().toISOString();

        res.json({
            success: true,
            workoutProgram: workoutProgram
        });

    } catch (error) {
        console.error('Error generating workout program:', error);
        res.status(500).json({
            error: 'Failed to generate workout program',
            details: error.message
        });
    }
});

// Helper function to create workout prompt
function createWorkoutPrompt(userProfile) {
    return `
Sen bir profesyonel fitness antrenörüsün. Kullanıcının bilgilerine göre kişiselleştirilmiş bir spor programı oluştur.

Kullanıcı Bilgileri:
- Yaş: ${userProfile.age || 'Belirtilmemiş'}
- Boy: ${userProfile.height || 'Belirtilmemiş'} cm
- Kilo: ${userProfile.weight || 'Belirtilmemiş'} kg
- Cinsiyet: ${userProfile.gender || 'Belirtilmemiş'}
- Hedef: ${userProfile.goal || 'Belirtilmemiş'}
- Spor Seviyesi: ${userProfile.fitnessLevel || 'Belirtilmemiş'}
- Antrenman Yeri: ${userProfile.workoutLocation || 'Belirtilmemiş'}
- Mevcut Ekipmanlar: ${userProfile.availableEquipment?.join(', ') || 'Belirtilmemiş'}

Lütfen aşağıdaki JSON formatında bir spor programı oluştur:

{
  "programName": "Program Adı",
  "description": "Program açıklaması",
  "durationWeeks": 4,
  "difficulty": "beginner/intermediate/advanced",
  "weeklySchedule": [
    {
      "dayName": "Monday",
      "focus": "Upper Body",
      "estimatedDuration": 45,
      "notes": "Günlük notlar",
      "exercises": [
        {
          "name": "Push-ups",
          "sets": 3,
          "reps": 12,
          "weight": "bodyweight",
          "restSeconds": 60,
          "notes": "Egzersiz notları"
        }
      ]
    }
  ]
}

Önemli Kurallar:
1. Kullanıcının seviyesine uygun egzersizler seç
2. Mevcut ekipmanları kullan
3. Hedefine uygun program tasarla
4. Güvenli ve etkili egzersizler öner
5. Sadece JSON formatında yanıt ver, başka açıklama ekleme
6. Haftalık program en az 3 gün olmalı
7. Her gün için 4-8 egzersiz öner
`;
}

// Fallback workout program
function createFallbackWorkout(userProfile) {
    const goals = {
        'weight_loss': {
            programName: 'Kilo Verme Programı',
            description: 'Kardiyovasküler sağlığı artıran ve kalori yakımını destekleyen program',
            difficulty: 'beginner'
        },
        'muscle_gain': {
            programName: 'Kas Kazanma Programı',
            description: 'Kas kütlesi artırımına odaklanan güç antrenmanı programı',
            difficulty: 'intermediate'
        },
        'endurance': {
            programName: 'Dayanıklılık Programı',
            description: 'Kardiyovasküler dayanıklılığı artıran program',
            difficulty: 'beginner'
        },
        'general_fitness': {
            programName: 'Genel Fitness Programı',
            description: 'Genel sağlık ve fitness seviyesini artıran dengeli program',
            difficulty: 'beginner'
        }
    };

    const goal = userProfile.goal || 'general_fitness';
    const program = goals[goal] || goals['general_fitness'];

    return {
        programName: program.programName,
        description: program.description,
        durationWeeks: 4,
        difficulty: program.difficulty,
        weeklySchedule: [
            {
                dayName: 'Monday',
                focus: 'Upper Body',
                estimatedDuration: 45,
                notes: 'Üst vücut güçlendirme',
                exercises: [
                    { name: 'Push-ups', sets: 3, reps: 12, weight: 'bodyweight', restSeconds: 60, notes: 'Tam hareket açıklığında' },
                    { name: 'Dumbbell Rows', sets: 3, reps: 10, weight: '5-10kg', restSeconds: 90, notes: 'Kontrollü hareket' },
                    { name: 'Shoulder Press', sets: 3, reps: 8, weight: '5-8kg', restSeconds: 90, notes: 'Omuz stabilitesi' },
                    { name: 'Tricep Dips', sets: 3, reps: 10, weight: 'bodyweight', restSeconds: 60, notes: 'Sandalyede' }
                ]
            },
            {
                dayName: 'Wednesday',
                focus: 'Lower Body',
                estimatedDuration: 45,
                notes: 'Alt vücut güçlendirme',
                exercises: [
                    { name: 'Squats', sets: 3, reps: 15, weight: 'bodyweight', restSeconds: 60, notes: 'Dizler ayak parmaklarını geçmesin' },
                    { name: 'Lunges', sets: 3, reps: 12, weight: 'bodyweight', restSeconds: 60, notes: 'Her bacak için' },
                    { name: 'Calf Raises', sets: 3, reps: 20, weight: 'bodyweight', restSeconds: 45, notes: 'Yavaş ve kontrollü' },
                    { name: 'Glute Bridges', sets: 3, reps: 15, weight: 'bodyweight', restSeconds: 60, notes: 'Kalça kaslarını sık' }
                ]
            },
            {
                dayName: 'Friday',
                focus: 'Full Body',
                estimatedDuration: 50,
                notes: 'Tam vücut antrenmanı',
                exercises: [
                    { name: 'Burpees', sets: 3, reps: 8, weight: 'bodyweight', restSeconds: 90, notes: 'Tam hareket' },
                    { name: 'Mountain Climbers', sets: 3, reps: 20, weight: 'bodyweight', restSeconds: 60, notes: 'Hızlı tempo' },
                    { name: 'Plank', sets: 3, reps: 1, weight: 'bodyweight', restSeconds: 60, notes: '30-45 saniye' },
                    { name: 'Jumping Jacks', sets: 3, reps: 30, weight: 'bodyweight', restSeconds: 45, notes: 'Kardiyovasküler' }
                ]
            }
        ]
    };
}

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 FitSun Backend Server running on port ${PORT}`);
    console.log(`📱 API Base URL: http://localhost:${PORT}`);
    console.log(`🔗 Health Check: http://localhost:${PORT}/api/health`);
});

module.exports = app;
