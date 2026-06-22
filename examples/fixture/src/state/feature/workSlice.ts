import type { AppState } from '../contracts';

export interface WorkItem {
  id: string;
  side: 'left' | 'right';
  status: 'queued' | 'done' | 'error';
}

export const addQueuedItem = (side: 'left' | 'right'): WorkItem => ({
  id: 'fixture-item',
  side,
  status: 'queued',
});

export const selectQueuedItems = (state: AppState) =>
  state.work.items.filter((item) => item.status === 'queued');
