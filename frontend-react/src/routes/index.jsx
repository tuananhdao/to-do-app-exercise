import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import MainLayout from '../components/layout/MainLayout';
import Home from '../pages/Home';
import TodoPage from '../pages/TodoPage';
import ActiveTodos from '../pages/ActiveTodos';
import CompletedTodos from '../pages/CompletedTodos';
import NotFound from '../pages/NotFound';

const router = createBrowserRouter([
    {
        path: '/',
        element: <MainLayout />,
        children: [
            {
                index: true,
                element: <Home />,
            },
            {
                path: 'todos',
                element: <TodoPage />,
            },
            {
                path: 'todos/active',
                element: <ActiveTodos />,
            },
            {
                path: 'todos/completed',
                element: <CompletedTodos />,
            },
        ],
    },
    {
        path: '*',
        element: <NotFound />,
    },
]);

export default function AppRouter() {
    return <RouterProvider router={router} />;
}
