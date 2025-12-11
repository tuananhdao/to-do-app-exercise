import { useEffect } from 'react';
import './Toast.css';

export default function Toast({ message, type = 'error', onClose }) {
    useEffect(() => {
        if (message) {
            const timer = setTimeout(() => {
                onClose();
            }, 3000);
            return () => clearTimeout(timer);
        }
    }, [message, onClose]);

    if (!message) return null;

    return (
        <div className={`toast toast-${type}`}>
            <span className="toast-icon">
                {type === 'error' ? '❌' : '✅'}
            </span>
            <span className="toast-message">{message}</span>
            <button className="toast-close" onClick={onClose}>×</button>
        </div>
    );
}
