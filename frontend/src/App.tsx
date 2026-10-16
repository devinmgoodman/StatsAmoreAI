import { useQuery } from '@tanstack/react-query'
import { fetchHealth } from './api/health.ts'

export default function App() {
  const { data, isPending, isError } = useQuery({ queryKey: ['health'], queryFn: fetchHealth })

  return (
    <main className="mx-auto max-w-md p-4">
      <h1 className="text-2xl font-bold">StatsAmoreAI</h1>
      <p className="mt-2 text-sm text-gray-600">
        API: {isPending ? 'checking…' : isError ? 'unreachable' : `${data.status} (db ${data.db})`}
      </p>
    </main>
  )
}
