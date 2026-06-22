interface ResourceMap {
  first: string[];
  second: string[];
}

const RESOURCES: ResourceMap = {
  first: ['/assets/first-a.txt', '/assets/first-b.txt'],
  second: ['/assets/second-a.txt'],
};

export const pickResource = (step: 'draft' | 'active' | 'archived') => {
  if (step === 'archived') {
    return RESOURCES.second[0];
  }

  return RESOURCES.first[0];
};
