import { getApiBaseUrl } from '../config/env';

export const loadItems = () => fetch(`${getApiBaseUrl()}/items`);
