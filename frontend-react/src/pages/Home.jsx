import { Link } from 'react-router-dom';
import './Home.css';

export default function Home() {
    return (
        <div className="home-page">
            <div className="hero-section">
                <h1 className="hero-title">
                    Welcome to Todo App 🚀
                </h1>
                <p className="hero-description">
                    Organize your tasks efficiently with our modern, intuitive todo application.
                    Keep track of your daily activities and boost your productivity.
                </p>
                <div className="cta-buttons">
                    <Link to="/todos" className="btn btn-primary">
                        Get Started
                    </Link>
                    <Link to="/todos/active" className="btn btn-secondary">
                        View Active Tasks
                    </Link>
                </div>
            </div>

            <div className="features-section">
                <h2 className="features-title">Features</h2>
                <div className="features-grid">
                    <div className="feature-card">
                        <div className="feature-icon">✅</div>
                        <h3>Task Management</h3>
                        <p>Create, edit, and delete tasks with ease</p>
                    </div>
                    <div className="feature-card">
                        <div className="feature-icon">🎯</div>
                        <h3>Filter & Sort</h3>
                        <p>View active or completed tasks separately</p>
                    </div>
                    <div className="feature-card">
                        <div className="feature-icon">💾</div>
                        <h3>Local Storage</h3>
                        <p>Your tasks are saved automatically</p>
                    </div>
                    <div className="feature-card">
                        <div className="feature-icon">📱</div>
                        <h3>Responsive Design</h3>
                        <p>Works perfectly on all devices</p>
                    </div>
                </div>
            </div>
        </div>
    );
}
