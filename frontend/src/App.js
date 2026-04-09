import React, { useState } from 'react';

function App() {
  // ZUSTÄNDE (States) für Interaktion
  const [isHovered, setIsHovered] = useState(false);
  const [isDeploying, setIsDeploying] = useState(false); // Zeigt Lade-Zustand an
  const [deployCount, setDeployCount] = useState(0);   // Zählt Klicks

  // FUNKTION, die beim Klick ausgeführt wird
  const handleDeploy = () => {
    if (isDeploying) return; // Verhindert mehrfaches Klicken

    setIsDeploying(true);
    setDeployCount(prev => prev + 1);

    // Simuliert eine Blockchain-Interaktion für 2,5 Sekunden
    setTimeout(() => {
      setIsDeploying(false);
      alert("✅ STAKING DEPLOYED SUCCESSFULLY!\nTransaction Hash: 0x" + Math.random().toString(16).slice(2, 10) + "... (Simulated)");
    }, 2500);
  };

  return (
    <div style={{ 
      textAlign: 'center', 
      backgroundColor: '#0a0a0a', 
      color: '#d4af37', 
      padding: '50px', 
      height: '100vh',
      fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif'
    }}>
      {/* CSS für den Lade-Spinner (wird nur geladen, wenn deploying) */}
      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>

      <header style={{ marginBottom: '50px' }}>
        <h1 style={{ 
          fontSize: '3.5rem', 
          textTransform: 'uppercase', 
          letterSpacing: '3px',
          margin: '0 0 10px 0',
          textShadow: '0 0 15px rgba(212, 175, 55, 0.5)'
        }}>
          🏰 Saint Tropez Royal Yield
        </h1>
        <p style={{ fontStyle: 'italic', fontSize: '1.3rem', color: '#f0e68c', marginTop: '0' }}>
          Exclusive Web3 Investment Interface
        </p>
      </header>

      <main>
        <div style={{ 
          border: '1px solid #d4af37', 
          padding: '40px', 
          borderRadius: '30px', 
          display: 'inline-block',
          backgroundColor: '#141414',
          boxShadow: '0 10px 30px rgba(0, 0, 0, 0.5)'
        }}>
          <h2 style={{ 
            borderBottom: '2px solid #333', 
            paddingBottom: '15px',
            textTransform: 'uppercase',
            letterSpacing: '1px',
            color: 'white'
          }}>
            Portfolio Overview
          </h2>
          
          <div style={{ margin: '30px 0', fontSize: '1.6rem' }}>
            <p>Status: <span style={{ color: '#2ecc71', fontWeight: 'bold' }}>Connected ✅</span></p>
            <p>Current Yield: <span style={{ fontWeight: 'bold', fontSize: '2rem' }}>12.5% APY</span></p>
            {deployCount > 0 && (
              <p style={{ fontSize: '0.9rem', opacity: '0.6', marginTop: '10px' }}>
                Deploys initiated: {deployCount}
              </p>
            )}
          </div>

          {/* INTERAKTIVER WEB3 BUTTON */}
          <button 
            onClick={handleDeploy} // Ruft die Funktion auf
            onMouseEnter={() => setIsHovered(true)}
            onMouseLeave={() => setIsHovered(false)}
            disabled={isDeploying} // Button wird während des Ladens grau
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              margin: '0 auto',
              backgroundColor: isDeploying ? '#333' : (isHovered ? '#d4af37' : 'transparent'),
              color: isDeploying ? '#888' : (isHovered ? 'black' : '#d4af37'),
              border: isDeploying ? '2px solid #333' : '2px solid #d4af37',
              padding: '15px 40px',
              borderRadius: '50px',
              fontWeight: 'bold',
              cursor: isDeploying ? 'wait' : 'pointer',
              fontSize: '1.1rem',
              textTransform: 'uppercase',
              letterSpacing: '1px',
              transition: 'all 0.3s ease',
              boxShadow: (isHovered && !isDeploying) ? '0 0 20px rgba(212, 175, 55, 0.6)' : 'none',
              opacity: isDeploying ? 0.7 : 1
            }}
          >
            {isDeploying && (
              <div style={{
                border: '2px solid #f3f3f3',
                borderTop: '2px solid #d4af37',
                borderRadius: '50%',
                width: '14px',
                height: '14px',
                marginRight: '12px',
                animation: 'spin 1s linear infinite' // Lade-Animation
              }} />
            )}
            {isDeploying ? 'DEPLOYING...' : 'DEPLOY STAKING'}
          </button>
        </div>
      </main>

      <footer style={{ marginTop: '80px', fontSize: '0.9rem', opacity: '0.5', color: 'white' }}>
        © 2026 Saint Tropez Royal Yield - Secure Blockchain Protocol
      </footer>
    </div>
  );
}

export default App;