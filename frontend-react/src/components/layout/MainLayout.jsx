import { Outlet } from 'react-router-dom';
import './MainLayout.css';

export default function MainLayout() {
    const handleVoiceInput = () => {
        // TODO: Implement voice input functionality
        console.log('Voice input clicked');
        alert('Voice input feature - Coming soon!');
    };

    return (
        <div className="app-container">
            <div className="notebook">
                <header className="app-header">
                    <div className="header-content">
                        <h1 className="logo">
                            <span className="logo-main">To do list</span>
                            <span className="logo-tag">app</span>
                        </h1>
                        <button 
                            className="voice-btn" 
                            onClick={handleVoiceInput}
                            aria-label="Voice input"
                            title="Add task by voice"
                        >
                            🎤
                        </button>
                    </div>
                </header>

                <main className="main-content">
                    <Outlet />
                </main>
            </div>
        </div>
    );
}
