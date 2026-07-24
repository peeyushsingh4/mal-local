export const categories = [
  { id: 'services', name: 'Services', icon: '🔧', color: '#3b82f6' }, // blue
  { id: 'goods', name: 'Goods', icon: '📦', color: '#a855f7' }, // purple
  { id: 'lending', name: 'Lending', icon: '🤝', color: '#22c55e' }, // green
  { id: 'food', name: 'Food', icon: '🍱', color: '#ff7f50' }, // coral/orange
  { id: 'requests', name: 'Requests', icon: '🙏', color: '#ec4899' }, // pink
  { id: 'skills', name: 'Skills', icon: '🎓', color: '#eab308' }, // yellow
];

export function getCategoryById(id) {
  return categories.find(c => c.id === id) || null;
}

export function getCategoryColor(id) {
  const cat = getCategoryById(id);
  return cat ? cat.color : '#94a3b8'; // default slate color
}
