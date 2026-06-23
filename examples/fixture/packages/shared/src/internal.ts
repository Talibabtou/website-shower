import type { SharedStatus } from './index';

export const INTERNAL_STATUS_LABELS: Record<SharedStatus, string> = {
  idle: 'Idle',
  ready: 'Ready',
  failed: 'Failed',
};
