async function generateSubjectiveData(patientUid) {
    if (!patientUid || patientUid === "YOUR_PATIENT_ID_HERE") {
        console.error("❌ Error: Please put the Patient UID in the function call at the bottom!");
        return;
    }

    console.log(`🚀 Generating 14 days of Subjective Data for: ${patientUid}...`);

    // Import Firebase (uses the same version as your dashboard)
    const { getFirestore, collection, addDoc } = await import("https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js");
    const { initializeApp } = await import("https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js");

    // Config (Same as dashboard)
    const firebaseConfig = {
        apiKey: "AIzaSyDPLgw_-KggBhUAVwjpZnA9f3zWgZ-Qfg4",
        authDomain: "desboirat.firebaseapp.com",
        projectId: "desboirat",
        storageBucket: "desboirat.firebasestorage.app",
        messagingSenderId: "207065876556",
        appId: "1:207065876556:web:f7e50605d0b0711d3d4ce9",
        measurementId: "G-H4NPWJLEB4"
    };

    // Initialize specific instance for this script
    const app = initializeApp(firebaseConfig, "generator"); 
    const db = getFirestore(app);
    
    const resultsRef = collection(db, `users/${patientUid}/results`);

    // Helper to get random int between min and max
    const r = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;

    // Generate for the last 14 days
    for (let i = 14; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i); // Go back i days
        date.setHours(18, 30, 0); // Set to 6:30 PM

        // PROFILE: "Memory Issues" 
        // 0=Never (Good), 4=Often (Bad)
        
        // Q0: Atenció (Going into room...) -> Good (0-1)
        // Q1: Velocitat (Slower activity) -> Medium (1-2)
        // Q2: Fluència (Word finding) -> Medium (1-2)
        // Q3: Atenció (Lost thread) -> Good (0-1)
        // Q4: Memòria (Forgot recent info) -> BAD (3-4)
        // Q5: Memòria (Already knew info) -> BAD (3-4)
        // Q6: Executives (Decisions) -> Medium (2)
        // Q7: Executives (Planning) -> Good (1)

        await addDoc(resultsRef, {
            testName: 'qüestionari_subjectiu',
            answers_map: {
                "0": r(0, 1), // Atenció
                "1": r(1, 2), // Velocitat
                "2": r(1, 2), // Fluència
                "3": r(0, 1), // Atenció
                "4": r(3, 4), // Memòria (High Deficit!)
                "5": r(3, 4), // Memòria (High Deficit!)
                "6": r(1, 2), // Executiu
                "7": r(0, 2)  // Executiu
            },
            timestamp: date
        });
        
        console.log(`Saved questionnaire for day -${i}`);
    }

    console.log("✅ Done! Refresh the Patient Details view.");
    alert("Dades subjectives generades! Torna a clicar al pacient per veure el gràfic.");
}

// 👇 REPLACE THIS ID WITH THE ONE FROM YOUR DASHBOARD LIST 👇
generateSubjectiveData("demo_maria");