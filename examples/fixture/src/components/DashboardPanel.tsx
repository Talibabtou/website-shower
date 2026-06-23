'use client';

import dynamic from 'next/dynamic';
import { useEffect, useState } from 'react';

type DashboardPanelProps = {
  mode: 'compact' | 'expanded';
  variant: 'primary' | 'secondary';
  items: Array<{ id: string; imageUrl: string; label: string }>;
};

const HeavyChart = dynamic(() => import('./MetricCard'));

export function DashboardPanel({ mode, variant, items }: DashboardPanelProps) {
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [records, setRecords] = useState(items);

  useEffect(() => {
    fetch('/api/items')
      .then((response) => response.json())
      .then((data) => {
        setRecords(data.items);
        setIsLoading(false);
      })
      .catch(() => {
        setError('failed');
        setIsLoading(false);
      });
  }, []);

  if (isLoading) {
    return <div className="p-6 text-sm text-slate-500">Loading</div>;
  }

  if (error) {
    return <div className="p-6 text-sm text-red-600">Error</div>;
  }

  if (records.length === 0) {
    return <div className="p-6 text-sm text-slate-500">Empty</div>;
  }

  return (
    <section data-mode={mode} data-variant={variant}>
      <HeavyChart label="chart" tone="blue" />
      {records.map((item) => (
        <article key={item.id}>
          <img src={item.imageUrl} alt="" />
          <span>{item.label}</span>
        </article>
      ))}
    </section>
  );
}
