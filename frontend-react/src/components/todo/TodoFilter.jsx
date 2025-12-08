import './TodoFilter.css';

export default function TodoFilter({ currentFilter, onFilterChange }) {
    const filters = [
        { value: 'all', label: 'All' },
        { value: 'active', label: 'Active' },
        { value: 'completed', label: 'Completed' },
    ];

    return (
        <div className="todo-filter">
            {filters.map(filter => (
                <button
                    key={filter.value}
                    className={`filter-btn ${currentFilter === filter.value ? 'active' : ''}`}
                    onClick={() => onFilterChange(filter.value)}
                >
                    {filter.label}
                </button>
            ))}
        </div>
    );
}
