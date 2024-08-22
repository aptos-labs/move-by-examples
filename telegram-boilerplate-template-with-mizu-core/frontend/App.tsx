// Internal Components
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Header } from "@/components/Header";
import { Counter } from "@/components/Counter";
import { useMizuWallet } from "@/components/WalletProvider";

function App() {
  const { mizuClient } = useMizuWallet();

  return (
    <>
      <Header />
      <div className="flex items-center justify-center flex-col">
        {mizuClient ? (
          <Card>
            <CardContent className="flex flex-col gap-10 pt-6">
              <Counter />
            </CardContent>
          </Card>
        ) : (
          <CardHeader>
            <CardTitle>To get started Connect a wallet</CardTitle>
          </CardHeader>
        )}
      </div>
    </>
  );
}

export default App;
