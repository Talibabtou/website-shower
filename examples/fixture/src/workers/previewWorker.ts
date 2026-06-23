interface PreviewWorkerRequest {
  type: 'preview_requested';
  payload: {
    itemId: string;
    side: 'left' | 'right';
  };
}

interface PreviewWorkerResponse {
  type: 'preview_ready';
  payload: {
    itemId: string;
    imageUrl: string;
  };
}

export const computePreview = (
  request: PreviewWorkerRequest,
): PreviewWorkerResponse => ({
  type: 'preview_ready',
  payload: {
    itemId: request.payload.itemId,
    imageUrl: `/preview/${request.payload.itemId}.png`,
  },
});
