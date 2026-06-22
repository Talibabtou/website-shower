interface ResourceMap {
  first: string[];
  second: string[];
}

const RESOURCES: ResourceMap = {
  first: ['/assets/first-a.txt', '/assets/first-b.txt'],
  second: ['/assets/second-a.txt'],
};

export const getResourcesToPreload = () => [
  ...RESOURCES.first,
  ...RESOURCES.second,
];
