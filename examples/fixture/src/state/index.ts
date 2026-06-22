export const store = {
  getState: () => ({
    work: {
      items: [],
    },
    resolution: {
      kind: null,
      results: [],
    },
  }),
};

export type AppState = ReturnType<typeof store.getState>;

export * from './contracts';
