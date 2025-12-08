# Todo App - React Frontend

Ứng dụng quản lý công việc (Todo App) được xây dựng với **React 19**, **Vite 7**, và **React Router v6**.

## Tính Năng

- Thêm, sửa, xóa todo
- Đánh dấu hoàn thành/chưa hoàn thành
- Lọc theo trạng thái (All, Active, Completed)
- Lưu trữ tự động với LocalStorage
- Thiết kế responsive cho mọi thiết bị
- Giao diện hiện đại với CSS animations

## Cấu Trúc Dự Án

```
frontend-react/
├── public/                      # Static assets
├── src/
│   ├── components/             # Reusable components
│   │   ├── common/            # Common UI components
│   │   ├── layout/            # Layout components (Header, Footer, MainLayout)
│   │   └── todo/              # Todo-specific components
│   ├── pages/                  # Page components
│   │   ├── Home.jsx           # Trang chủ
│   │   ├── TodoPage.jsx       # Trang quản lý todo
│   │   ├── ActiveTodos.jsx    # Trang todo đang hoạt động
│   │   ├── CompletedTodos.jsx # Trang todo đã hoàn thành
│   │   └── NotFound.jsx       # Trang 404
│   ├── hooks/                  # Custom React hooks
│   │   ├── useTodos.js        # Hook quản lý todos
│   │   └── useLocalStorage.js # Hook lưu trữ local
│   ├── services/               # API services
│   │   ├── api.js             # Base API config
│   │   └── todoService.js     # Todo CRUD operations
│   ├── utils/                  # Utility functions
│   │   └── constants.js       # App constants
│   ├── routes/                 # Route configuration
│   │   └── index.jsx          # React Router setup
│   ├── App.jsx                 # Main App component
│   └── main.jsx               # Entry point
├── .dockerignore              # Docker ignore file
├── .env.example               # Environment variables example
├── Dockerfile                 # Docker configuration
├── package.json               # Dependencies
└── vite.config.js             # Vite configuration (Port 5173)
```

## Routes

| Route | Mô Tả |
|-------|-------|
| `/` | Trang chủ với giới thiệu tính năng |
| `/todos` | Trang quản lý tất cả todos |
| `/todos/active` | Todos đang hoạt động |
| `/todos/completed` | Todos đã hoàn thành |
| `*` | Trang 404 Not Found |

## Cài Đặt và Chạy

### Yêu cầu
- Node.js >= 20
- npm hoặc yarn

### Development

```bash
# Cài đặt dependencies
npm install

# Chạy dev server (port 5173)
npm run dev
```

Mở trình duyệt tại: `http://localhost:5173`

### Build Production

```bash
# Build cho production
npm run build

# Preview production build
npm run preview
```

## Docker

### Build Docker Image

```bash
docker build -t todo-app-frontend .
```

### Run Docker Container

```bash
docker run -p 5173:5173 todo-app-frontend
```

Truy cập ứng dụng tại: `http://localhost:5173`

## Component Structure

### Layout Components
- **MainLayout**: Layout chính với header, navigation, và footer
- **Header**: Thanh điều hướng với các links

### Todo Components
- **TodoForm**: Form thêm todo mới
- **TodoList**: Danh sách todos
- **TodoItem**: Item todo với edit, delete, toggle
- **TodoFilter**: Bộ lọc todos (All/Active/Completed)

### Pages
- **Home**: Landing page với hero section và features
- **TodoPage**: Trang quản lý todos với stats
- **ActiveTodos**: Hiển thị todos chưa hoàn thành
- **CompletedTodos**: Hiển thị todos đã hoàn thành
- **NotFound**: Trang 404

## Backend Integration

Dự án đã chuẩn bị sẵn services để tích hợp với backend API. Xem file:
- `src/services/api.js` - Base API configuration
- `src/services/todoService.js` - Todo CRUD operations

Cập nhật `.env` với backend URL:
```env
VITE_API_BASE_URL=http://localhost:8080/api
```

## Scripts

| Script | Mô Tả |
|--------|-------|
| `npm run dev` | Chạy development server |
| `npm run build` | Build production |
| `npm run preview` | Preview production build |
| `npm run lint` | Lint code |

## Tech Stack

- **React 19** - UI Library
- **Vite 7** - Build tool & Dev server
- **React Router v6** - Routing
- **CSS3** - Styling (no framework)
- **Docker** - Containerization
