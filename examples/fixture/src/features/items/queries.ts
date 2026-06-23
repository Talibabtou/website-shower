export const itemQueryKey = ['items'];

export const loadItemsForQuery = async () => {
  const response = await fetch('/api/items', {
    cache: 'no-store',
  });
  return response.json() as Promise<{ items: Array<{ id: string }> }>;
};
