interface DomainEvent {
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

export const consumeEvent = (
  event: DomainEvent,
  selectedSide: 'left' | 'right',
) => ({
  event,
  selectedSide,
});
