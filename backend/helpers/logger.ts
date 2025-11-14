import winston from "winston";
import DailyRotateFile from "winston-daily-rotate-file";
import path from "path";

function getCaller() {
  const err = new Error();
  const stack = err.stack?.split("\n");

  if (!stack || stack.length < 4) {
    return { file: "unknown", fn: "unknown" };
  }

  const line = stack[3];

  const fileMatch =
    line.match(/\((.*):\d+:\d+\)/) || line.match(/at (.*):\d+:\d+/);

  const filePath = fileMatch ? fileMatch[1] : "unknown";
  const file = path.basename(filePath);

  const fnMatch = line.match(/at (?:(\S+) )?\(/);
  const fn = fnMatch && fnMatch[1] ? fnMatch[1] : "anonymous";

  return { file, fn };
}

const format = winston.format.combine(
  winston.format.timestamp({ format: "YYYY-MM-DD HH:mm:ss" }),
  winston.format.printf((info) => {
    const context = info.context as { file?: string; fn?: string } | undefined;

    const file = context?.file ?? "unknown";
    const fn = context?.fn ?? "unknown";

    return `[${info.timestamp}] [${info.level.toUpperCase()}] ${file}:${fn} | ${
      info.message
    }`;
  })
);

export const logger = winston.createLogger({
  level: "info",
  format,
  transports: [
    new winston.transports.Console(),
    new DailyRotateFile({
      dirname: "../logs",
      filename: "%DATE%.log",
      datePattern: "YYYY-MM-DD",
      zippedArchive: true,
      maxSize: "10m",
      maxFiles: "30d",
    }),
  ],
});

function auto(level: "info" | "warn" | "error" | "debug", msg: string) {
  const caller = getCaller();
  logger.log(level, msg, { context: caller });
}

export const log = {
  info: (msg: string) => auto("info", msg),
  warn: (msg: string) => auto("warn", msg),
  error: (msg: string) => auto("error", msg),
  debug: (msg: string) => auto("debug", msg),
};
