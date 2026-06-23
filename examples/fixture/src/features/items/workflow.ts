export type ItemStatus = 'draft' | 'active' | 'archived';

export const itemStatusLabels: Record<ItemStatus, string> = {
  draft: 'Draft',
  active: 'Active',
  archived: 'Archived',
};
