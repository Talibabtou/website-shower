import { mapSharedStatus } from '@fixture/shared';
import { INTERNAL_STATUS_LABELS } from '@fixture/shared/internal';

type SharedStatus = 'idle' | 'ready' | 'failed';

export const readSharedStatus = (status: SharedStatus) => ({
  label: INTERNAL_STATUS_LABELS[status],
  mapped: mapSharedStatus(status),
});
