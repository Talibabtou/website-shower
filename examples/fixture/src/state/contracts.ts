export interface AppState {
  work: WorkState;
}

export type ProcessStep = 'draft' | 'active' | 'archived';

export interface WorkState {
  items: WorkItem[];
}

export interface WorkItem {
  id: string;
  side: 'left' | 'right';
  status: 'queued' | 'done' | 'error';
}

export interface DomainEvent {
  type: 'item_resolved';
  data: {
    itemId: string;
    amount: number;
    participants: Array<{
      id: string;
      amount: number;
    }>;
  };
}
