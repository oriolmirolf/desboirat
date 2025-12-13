// seed.js

// 1. IMPORT FIREBASE (Standard ES Modules)
import { initializeApp } from "firebase/app";
import { getFirestore, collection, doc, setDoc, addDoc } from "firebase/firestore";

// --- 🔴 CONFIGURATION 🔴 ---
// Use the exact same config from your website
const firebaseConfig = {
    apiKey: "AIzaSyDPLgw_-KggBhUAVwjpZnA9f3zWgZ-Qfg4",
    authDomain: "desboirat.firebaseapp.com",
    projectId: "desboirat",
    storageBucket: "desboirat.firebasestorage.app",
    messagingSenderId: "207065876556",
    appId: "1:207065876556:web:f7e50605d0b0711d3d4ce9",
    measurementId: "G-H4NPWJLEB4"
};

// --- 🔴 SETTINGS 🔴 ---
const DOCTOR_UID = "Mfa7vzzw9sg25jYxFu9IVCdFIW92"; // <--- PASTE YOUR DOCTOR ID HERE

// Initialize
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const generateData = async () => {
    if (DOCTOR_UID === "YOUR_DOCTOR_UID_HERE") {
        console.error("❌ ERROR: You must paste your Doctor UID in the script first!");
        process.exit(1);
    }

    console.log(`🚀 Starting Seed for Doctor: ${DOCTOR_UID}`);

    // --- DEFINING PATIENT PROFILES ---
    const patients = [
        { 
            name: "Maria Garcia", 
            email: "maria.garcia@demo.cat", 
            profile: "stable" // Scores stay roughly the same
        },
        { 
            name: "Joan Vila", 
            email: "joan.vila@demo.cat", 
            profile: "declining" // Scores get worse over 2 weeks
        },
        { 
            name: "Anna Pi", 
            email: "anna.pi@demo.cat", 
            profile: "improving" // Scores get better (rehab working)
        }
    ];

    for (const p of patients) {
        // Create a deterministic but unique ID
        const uid = `demo_${p.name.split(' ')[0].toLowerCase()}`;
        console.log(`\n👤 Creating Patient: ${p.name} (${uid})...`);

        // 1. Create User Document
        await setDoc(doc(db, "users", uid), {
            email: p.email,
            doctorId: DOCTOR_UID,
            createdAt: new Date(),
            lastActive: new Date()
        });

        // 2. Generate 14 Days of Results
        const resultsRef = collection(db, `users/${uid}/results`);
        
        for (let i = 14; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i); // Go back 'i' days
            // Randomize time of day (9 AM - 8 PM)
            date.setHours(9 + Math.floor(Math.random() * 11), Math.floor(Math.random() * 59));

            // CALCULATE SCORES BASED ON PROFILE
            // factor: 0.0 (past) to 1.0 (today)
            // Used to interpolate improvement or decline
            const factor = (14 - i) / 14; 

            let fluency, speed, attention, memory;

            if (p.profile === "stable") {
                fluency = 18 + randInt(-2, 2);
                speed = 10.0 + (Math.random() * 2);
                attention = 6 + randInt(0, 1);
                memory = 4 + randInt(0, 1);
            } 
            else if (p.profile === "declining") {
                // Fluency drops from 20 to 12
                fluency = Math.floor(20 - (8 * factor)) + randInt(-1, 1);
                // Speed increases from 10s to 18s (slower is worse)
                speed = 10.0 + (8 * factor) + (Math.random());
                // Attention drops 7 -> 4
                attention = Math.floor(7 - (3 * factor));
                // Memory drops 5 -> 3
                memory = Math.floor(5 - (2 * factor));
            } 
            else if (p.profile === "improving") {
                // Fluency rises 10 -> 18
                fluency = Math.floor(10 + (8 * factor)) + randInt(-1, 1);
                // Speed drops 20s -> 9s (faster is better)
                speed = 20.0 - (11 * factor) + (Math.random());
                // Attention rises 4 -> 8
                attention = Math.floor(4 + (4 * factor));
                // Memory rises 3 -> 6
                memory = Math.floor(3 + (3 * factor));
            }

            // --- WRITE TESTS ---

            // 1. Fluència Verbal (80% chance)
            if (Math.random() > 0.2) {
                await addDoc(resultsRef, {
                    testName: 'fluencia_verbal',
                    score: fluency,
                    target_category: ['Animals', 'Fruites', 'Ciutats'][randInt(0,2)],
                    timestamp: new Date(date.getTime())
                });
            }

            // 2. Velocitat Processament (80% chance)
            if (Math.random() > 0.2) {
                await addDoc(resultsRef, {
                    testName: 'velocitat_processament',
                    score_time_seconds: parseFloat(speed.toFixed(2)),
                    timestamp: new Date(date.getTime() + 60000 * 5) // 5 mins later
                });
            }

            // 3. Atenció (Digit Span Forward) (60% chance)
            if (Math.random() > 0.4) {
                await addDoc(resultsRef, {
                    testName: 'atencio', // DISTINCT TEST NAME
                    score: attention,
                    test_type: 'forward',
                    timestamp: new Date(date.getTime() + 60000 * 10)
                });
            }

            // 4. Memòria Treball (Digit Span Reverse) (60% chance)
            if (Math.random() > 0.4) {
                await addDoc(resultsRef, {
                    testName: 'memoria_treball', // DISTINCT TEST NAME
                    score: memory,
                    test_type: 'reverse',
                    timestamp: new Date(date.getTime() + 60000 * 15)
                });
            }

            // 5. Subjective Questionnaire (Once a week)
            if (i % 7 === 0) {
                // Random answers based on profile (0=Good, 4=Bad)
                let baseBadness = p.profile === "declining" ? (i === 0 ? 3 : 1) : 1;
                
                await addDoc(resultsRef, {
                    testName: 'qüestionari_subjectiu',
                    answers_map: {
                        "0": Math.min(4, Math.max(0, baseBadness + randInt(-1, 1))),
                        "1": Math.min(4, Math.max(0, baseBadness + randInt(-1, 1))),
                        "2": Math.min(4, Math.max(0, baseBadness + randInt(-1, 1))),
                        "3": Math.min(4, Math.max(0, baseBadness + randInt(-1, 1))),
                        "4": Math.min(4, Math.max(0, baseBadness + randInt(-1, 1)))
                    },
                    timestamp: new Date(date.getTime() + 60000 * 30)
                });
            }
        }
    }

    console.log("\n✅ DONE! Database seeded with 3 patients.");
    process.exit(0);
};

// Helper for random integers
function randInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

generateData();