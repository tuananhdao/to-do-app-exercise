import { Outlet } from 'react-router-dom';
import './MainLayout.css';

export default function MainLayout() {
    return (
        <div className="app-container">
            <header className="app-header">
                <div className="header-content">
                    <h1 className="logo">📝 Todo List</h1>
                </div>
            </header>

            <main className="main-content">
                <Outlet />
            </main>
        </div>
    );
}
