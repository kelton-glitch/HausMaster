/// Riverpod 3 retries failed providers automatically with exponential backoff.
/// For us that would keep an offline user on a skeleton for minutes instead of
/// showing the error and its Retry button, so retrying is left to the user
/// (pull-to-refresh / Retry). Returning null means "do not retry".
Duration? noAutoRetry(int retryCount, Object error) => null;
