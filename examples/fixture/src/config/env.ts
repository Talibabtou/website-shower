export const API_BASE_URL = 'https://example.invalid/api';

export const getApiBaseUrl = () => API_BASE_URL;

export const getLegacyApiUrl = () => `${API_BASE_URL}/legacy`;

export const getUnusedCallbackUrl = () => `${API_BASE_URL}/callback`;

export const buildPreviewUrl = (itemId: string) =>
  `${API_BASE_URL}/preview/${itemId}`;
