import { Link } from 'react-router-dom';
import './NotFound.css';

export default function NotFound() {
    return (
        <div className="not-found-page">
            <div className="not-found-content">
                <h1 className="error-code">404</h1>
                <h2 className="error-message">Page Not Found</h2>
                <p className="error-description">
                    Oops! The page you're looking for doesn't exist.
                </p>
                <Link to="/" className="btn-home">
                    Go Back Home
                </Link>
            </div>
        </div>
    );
}
