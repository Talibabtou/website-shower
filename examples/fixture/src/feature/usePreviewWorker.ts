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

export const requestPreview = (
  itemId: string,
  side: 'left' | 'right',
): PreviewWorkerRequest => ({
  type: 'preview_requested',
  payload: {
    itemId,
    side,
  },
});

export const readPreviewUrl = (response: PreviewWorkerResponse) =>
  response.payload.imageUrl;
