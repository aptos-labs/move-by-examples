import { RouterProvider, createBrowserRouter, Outlet } from "react-router-dom";
// Internal pages
import { Mint } from "@/pages/Mint";
import { CreateFungibleAsset } from "@/pages/CreateFungibleAsset";
import { MyFungibleAssets } from "@/pages/MyFungibleAssets";

function Layout() {
  return (
    <>
      <Outlet />
    </>
  );
}

const router = createBrowserRouter([
  {
    element: <Layout />,
    children: [
      {
        path: "/mint/:faAddress",
        element: <Mint />,
      },
      {
        path: "create-asset",
        element: <CreateFungibleAsset />,
      },
      {
        path: "/",
        element: <MyFungibleAssets />,
      },
    ],
  },
]);

function App() {
  return (
    <>
      <RouterProvider router={router} />
    </>
  );
}

export default App;
