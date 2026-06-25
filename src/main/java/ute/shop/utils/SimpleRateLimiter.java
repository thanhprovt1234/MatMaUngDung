package ute.shop.utils;

import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public final class SimpleRateLimiter {
	private static final Map<String, Window> WINDOWS = new ConcurrentHashMap<>();
	private static final long CLEANUP_INTERVAL_MILLIS = 60_000;
	private static volatile long lastCleanupAt = System.currentTimeMillis();

	private SimpleRateLimiter() {
	}

	public static boolean allow(String key, int maxAttempts, long windowMillis) {
		long now = System.currentTimeMillis();
		cleanup(now);

		Window window = WINDOWS.computeIfAbsent(key, ignored -> new Window(now));
		synchronized (window) {
			if (now - window.startedAt >= windowMillis) {
				window.startedAt = now;
				window.count = 0;
			}
			window.count++;
			return window.count <= maxAttempts;
		}
	}

	private static void cleanup(long now) {
		if (now - lastCleanupAt < CLEANUP_INTERVAL_MILLIS) {
			return;
		}
		lastCleanupAt = now;
		Iterator<Map.Entry<String, Window>> iterator = WINDOWS.entrySet().iterator();
		while (iterator.hasNext()) {
			Map.Entry<String, Window> entry = iterator.next();
			if (now - entry.getValue().startedAt > 30 * 60_000L) {
				iterator.remove();
			}
		}
	}

	private static final class Window {
		private long startedAt;
		private int count;

		private Window(long startedAt) {
			this.startedAt = startedAt;
		}
	}
}
