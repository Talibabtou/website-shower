export const metadata = {
  title: 'Item detail',
};

export const dynamic = 'force-dynamic';

type ItemPageProps = {
  params: {
    id: string;
  };
};

export default async function ItemPage({ params }: ItemPageProps) {
  const response = await fetch(`/api/items/${params.id}`, {
    cache: 'no-store',
  });

  return <pre>{JSON.stringify(await response.json())}</pre>;
}
