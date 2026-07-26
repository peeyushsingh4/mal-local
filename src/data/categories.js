export const categories = [
  { id: 'food', name: 'Food & Tiffin', icon: '🍱', color: '#F7C413', bg: 'rgba(247, 196, 19, 0.15)' },
  { id: 'services', name: 'Services & Help', icon: '🔧', color: '#0C831F', bg: 'rgba(12, 131, 31, 0.15)' },
  { id: 'goods', name: 'Goods & Items', icon: '📦', color: '#38BDF8', bg: 'rgba(56, 189, 248, 0.15)' },
  { id: 'lending', name: 'Lending & Share', icon: '🤝', color: '#22C55E', bg: 'rgba(34, 197, 94, 0.15)' },
  { id: 'requests', name: 'Neighborhood Needs', icon: '🙏', color: '#EC4899', bg: 'rgba(236, 72, 153, 0.15)' },
  { id: 'skills', name: 'Skills & Classes', icon: '🎓', color: '#8B5CF6', bg: 'rgba(139, 92, 246, 0.15)' },
];

export function getCategoryById(id) {
  return categories.find(c => c.id === id) || null;
}

export function getCategoryColor(id) {
  const cat = getCategoryById(id);
  return cat ? cat.color : '#94a3b8';
}
