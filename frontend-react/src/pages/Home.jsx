import { Link } from 'react-router-dom';

export default function Home() {
    return (
        <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
            <div className="max-w-6xl mx-auto px-4 py-16">
                {/* Hero Section */}
                <div className="text-center mb-20">
                    <h1 className="text-5xl font-bold text-gray-900 mb-6">
                        Todo App
                    </h1>
                    <p className="text-xl text-gray-600 mb-10 max-w-2xl mx-auto">
                        Quản lý công việc hiệu quả với giao diện đơn giản, dễ sử dụng
                    </p>
                    <div className="flex gap-4 justify-center">
                        <Link 
                            to="/todos" 
                            className="btn btn-primary text-lg px-8 py-3"
                        >
                            Bắt đầu
                        </Link>
                        <Link 
                            to="/todos/active" 
                            className="btn btn-secondary text-lg px-8 py-3"
                        >
                            Xem công việc
                        </Link>
                    </div>
                </div>

                {/* Features Grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <div className="card p-6 hover:shadow-md transition-shadow">
                        <div className="text-4xl mb-4">✓</div>
                        <h3 className="text-lg font-semibold text-gray-900 mb-2">
                            Quản lý Task
                        </h3>
                        <p className="text-gray-600 text-sm">
                            Tạo, sửa, xóa công việc dễ dàng
                        </p>
                    </div>
                    
                    <div className="card p-6 hover:shadow-md transition-shadow">
                        <div className="text-4xl mb-4">○</div>
                        <h3 className="text-lg font-semibold text-gray-900 mb-2">
                            Lọc & Sắp xếp
                        </h3>
                        <p className="text-gray-600 text-sm">
                            Xem công việc đang làm hoặc đã hoàn thành
                        </p>
                    </div>
                    
                    <div className="card p-6 hover:shadow-md transition-shadow">
                        <div className="text-4xl mb-4">≡</div>
                        <h3 className="text-lg font-semibold text-gray-900 mb-2">
                            Multi-step
                        </h3>
                        <p className="text-gray-600 text-sm">
                            Chia nhỏ công việc thành các bước
                        </p>
                    </div>
                    
                    <div className="card p-6 hover:shadow-md transition-shadow">
                        <div className="text-4xl mb-4">⊞</div>
                        <h3 className="text-lg font-semibold text-gray-900 mb-2">
                            Giao diện đẹp
                        </h3>
                        <p className="text-gray-600 text-sm">
                            Thiết kế đơn giản, vuông vắn cho Windows
                        </p>
                    </div>
                </div>
            </div>
        </div>
    );
}
