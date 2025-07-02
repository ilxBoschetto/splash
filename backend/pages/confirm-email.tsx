import { useEffect, useState } from "react";
import { useRouter } from "next/router";

export default function ConfirmEmailPage() {
  const router = useRouter();
  const [message, setMessage] = useState("Conferma in corso...");

  useEffect(() => {
    const { token } = router.query;

    if (!token || typeof token !== "string") {
      setMessage("Token non valido.");
      return;
    }

    // Chiama l'endpoint API con il codice
    const confirm = async () => {
      try {
        const res = await fetch("/api/confirm-email", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ token }),
        });

        if (!res.ok) {
          const data = await res.json();
          throw new Error(data.error || "Errore durante la conferma");
        }

        setMessage("✅ Account confermato, ora puoi fare il login.");
      } catch (err: any) {
        setMessage(`❌ ${err.message}`);
      }
    };

    confirm();
  }, [router.query]);

  return (
    <div
      style={{
        fontFamily: "sans-serif",
        textAlign: "center",
        marginTop: "50px",
      }}
    >
      <h1>{message}</h1>
    </div>
  );
}
