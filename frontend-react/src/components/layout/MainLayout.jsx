import { Outlet } from 'react-router-dom';

export default function MainLayout() {
    return (
        <div className="h-screen flex flex-col bg-gray-50">
            <header className="bg-white border-b border-gray-200 shadow-sm flex-shrink-0">
                <div className="px-6 py-4">
                    <h1 className="text-2xl font-bold text-gray-900">
                        Todo List
                    </h1>
                </div>
            </header>

            <main className="flex-1 overflow-hidden">
                <Outlet />
            </main>
        </div>
    );
}
