import { useEffect, useState } from 'react';

export const metadata = {
  title: 'Items',
};

type ItemsPageProps = {
  searchParams: {
    view?: 'grid' | 'list';
  };
};

export default function ItemsPage({ searchParams }: ItemsPageProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null);

  useEffect(() => {
    setSelectedId(searchParams.view ?? null);
  }, [searchParams.view]);

  return <a href="/items/new">{selectedId ?? 'none'}</a>;
}
