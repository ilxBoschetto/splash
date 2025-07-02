import { useEffect, useState } from "react";
import { useRouter } from "next/router";

export default function ConfirmEmailPage() {
  const router = useRouter();
  const [message, setMessage] = useState("Conferma in corso...");
  const [hasFetched, setHasFetched] = useState(false);

  useEffect(() => {
    const token = router.query.token;

    if (!token || typeof token !== "string" || hasFetched) return;

    setHasFetched(true);

    const confirm = async () => {
      try {
        const res = await fetch("/api/user/confirm-email", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ token }),
        });

        const data = await res.json();

        if (!res.ok) {
          throw new Error(data.error || "Errore durante la conferma");
        }

        setMessage("✅ Account confermato, ora puoi fare il login.");
      } catch (err: any) {
        setMessage(`❌ ${err.message}`);
      }
    };

    confirm();
  }, [router.query.token, hasFetched]);

  return (
    <div
      style={{
        fontFamily: "sans-serif",
        textAlign: "center",
        marginTop: "50px",
        padding: "20px",
      }}
    >
      <h1>{message}</h1>
    </div>
  );
}
