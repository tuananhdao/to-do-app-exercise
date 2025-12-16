import { Link } from 'react-router-dom';

export default function NotFound() {
    return (
        <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
            <div className="text-center">
                <h1 className="text-9xl font-bold text-gray-300">404</h1>
                <h2 className="text-3xl font-semibold text-gray-900 mt-4">Không tìm thấy trang</h2>
                <p className="text-gray-600 mt-2 mb-8">
                    Trang bạn đang tìm kiếm không tồn tại.
                </p>
                <Link to="/" className="btn btn-primary text-lg px-8 py-3 inline-block">
                    Về trang chủ
                </Link>
            </div>
        </div>
    );
}
