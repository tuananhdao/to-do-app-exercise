import { Outlet, Link, useLocation } from 'react-router-dom';
import './MainLayout.css';

export default function MainLayout() {
    const location = useLocation();

    return (
        <div className="app-container">
            <header className="app-header">
                <div className="header-content">
                    <h1 className="logo">📝 Todo App</h1>
                    <nav className="nav-menu">
                        <Link
                            to="/"
                            className={location.pathname === '/' ? 'nav-link active' : 'nav-link'}
                        >
                            Home
                        </Link>
                        <Link
                            to="/todos"
                            className={location.pathname === '/todos' ? 'nav-link active' : 'nav-link'}
                        >
                            All Todos
                        </Link>
                        <Link
                            to="/todos/active"
                            className={location.pathname === '/todos/active' ? 'nav-link active' : 'nav-link'}
                        >
                            Active
                        </Link>
                        <Link
                            to="/todos/completed"
                            className={location.pathname === '/todos/completed' ? 'nav-link active' : 'nav-link'}
                        >
                            Completed
                        </Link>
                    </nav>
                </div>
            </header>

            <main className="main-content">
                <Outlet />
            </main>
        </div>
    );
}
