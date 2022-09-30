# ThreadLocal 相关知识点

## ThreadLocal
### 什么是 ThreadLocal

### ThreadLocal 使用场景

### ThreadLocal 源码分析

### ThreadLocal 存在的问题

## InheritableThreadLocal
### 什么是 InheritableThreadLocal

### InheritableThreadLocal 使用场景

### InheritableThreadLocal 源码分析

### InheritableThreadLocal 存在的问题

## TransmittableThreadLocal
### 什么是 TransmittableThreadLocal

### TransmittableThreadLocal.Transmitter

TransmittableThreadLocal.Transmitter 通过静态方法 capture() => replay(Object) => restore(Object)（又名 CRR 操作）将当前线程的所有 TransmittableThreadLocal 和注册的 ThreadLocal（由 registerThreadLocal 注册）值传输到其他线程。
TransmittableThreadLocal.Transmitter 是用于框架/中间件集成的内部操作 api； 通常，您永远不会在 biz/应用程序代码中使用它！
框架/中间件集成到 TTL 透射率

**ThreadLocal集成**
如果无法将现有的使用 ThreadLocal 的代码重写为 TransmittableThreadLocal，请通过 registerThreadLocal(ThreadLocal, TtlCopier)/registerThreadLocalWithShadowCopier(ThreadLocal) 方法注册 ThreadLocal 实例，以增强现有 ThreadLocal 实例的 Transmittable 能力。
Transmitter.registerThreadLocal(aThreadLocal, copyLambda);
Transmitter.unregisterThreadLocal(aThreadLocal);
如果注册的 ThreadLocal 实例不是 InheritableThreadLocal，则该实例不能从父线程继承值（也就是可继承能力）！



#### TransmittableThreadLocal.Transmitter.Snapshot

```
private static class Snapshot {
	final HashMap<TransmittableThreadLocal<Object>, Object> ttl2Value;
	final HashMap<ThreadLocal<Object>, Object> threadLocal2Value;

	private Snapshot(HashMap<TransmittableThreadLocal<Object>, Object> ttl2Value, HashMap<ThreadLocal<Object>, Object> threadLocal2Value) {
		this.ttl2Value = ttl2Value;
		this.threadLocal2Value = threadLocal2Value;
	}
}
```



#### TransmittableThreadLocal.Transmitter.capture()

```
// 捕获当前线程中的所有 TransmittableThreadLocal 和注册的 ThreadLocal 值
// 返回: 捕获的 TransmittableThreadLocal 值
@NonNull
public static Object capture() {
	return new Snapshot(captureTtlValues(), captureThreadLocalValues());
}
```

通过代码可知，调用 capture() 本质是生成一个当前线程的 TransmittableThreadLocal 和 ThreadLocal 值的快照 `Snapshot`(其内部使用HashMap存储)。



##### TransmittableThreadLocal.Transmitter.captureTtlValues()

```
private static HashMap<TransmittableThreadLocal<Object>, Object> captureTtlValues() {
	HashMap<TransmittableThreadLocal<Object>, Object> ttl2Value = new HashMap<TransmittableThreadLocal<Object>, Object>();
	for (TransmittableThreadLocal<Object> threadLocal : holder.get().keySet()) {
		ttl2Value.put(threadLocal, threadLocal.copyValue());
	}
	return ttl2Value;
}
```

生成一个当前线程 ttl 复制值的HashMap



##### TransmittableThreadLocal.Transmitter.captureThreadLocalValues()

```
private static HashMap<ThreadLocal<Object>, Object> captureThreadLocalValues() {
	final HashMap<ThreadLocal<Object>, Object> threadLocal2Value = new HashMap<ThreadLocal<Object>, Object>();
	for (Map.Entry<ThreadLocal<Object>, TtlCopier<Object>> entry : threadLocalHolder.entrySet()) {
		final ThreadLocal<Object> threadLocal = entry.getKey();
		final TtlCopier<Object> copier = entry.getValue();

		threadLocal2Value.put(threadLocal, copier.copy(threadLocal.get()));
	}
	return threadLocal2Value;
}
```

生成一个当前线程 tl 复制值的HashMap



#### TransmittableThreadLocal.Transmitter.replay()

```
// 从 capture() 中重放捕获的 TransmittableThreadLocal 和注册的 ThreadLocal 值，并在重放前返回当前线程中备份的 TransmittableThreadLocal 值。
// 参数: captured - 从 capture() 从其他线程捕获的 TransmittableThreadLocal 值
// 返回: 重播前的备份 TransmittableThreadLocal 值
@NonNull
public static Object replay(@NonNull Object captured) {
	final Snapshot capturedSnapshot = (Snapshot) captured;
	return new Snapshot(replayTtlValues(capturedSnapshot.ttl2Value), replayThreadLocalValues(capturedSnapshot.threadLocal2Value));
}
```

通过代码可知，调用 replay() 本质是生成一个当前线程的 TransmittableThreadLocal 和 ThreadLocal 值的快照 `Snapshot`，重放 capture() 返回的值。



##### TransmittableThreadLocal.Transmitter.replayTtlValues()

```
@NonNull
private static HashMap<TransmittableThreadLocal<Object>, Object> replayTtlValues(@NonNull HashMap<TransmittableThreadLocal<Object>, Object> captured) {
	HashMap<TransmittableThreadLocal<Object>, Object> backup = new HashMap<TransmittableThreadLocal<Object>, Object>();

	for (final Iterator<TransmittableThreadLocal<Object>> iterator = holder.get().keySet().iterator(); iterator.hasNext(); ) {
		TransmittableThreadLocal<Object> threadLocal = iterator.next();

		// 备份
		backup.put(threadLocal, threadLocal.get());

		// 清理不在 captured 中的 TTL 值
		// 运行任务时避免重放后的额外 TTL 值
		if (!captured.containsKey(threadLocal)) {
			iterator.remove();
			threadLocal.superRemove();
		}
	}

	// 将 TTL 值设置到captured
	setTtlValuesTo(captured);

	// 调用 beforeExecute 回调
	doExecuteCallback(true);

	return backup;
}
```



##### TransmittableThreadLocal.Transmitter.setTtlValuesTo()

```
private static void setTtlValuesTo(@NonNull HashMap<TransmittableThreadLocal<Object>, Object> ttlValues) {
	for (Map.Entry<TransmittableThreadLocal<Object>, Object> entry : ttlValues.entrySet()) {
		TransmittableThreadLocal<Object> threadLocal = entry.getKey();
		threadLocal.set(entry.getValue());
	}
}
```





##### TransmittableThreadLocal.Transmitter.replayThreadLocalValues()

```
private static HashMap<ThreadLocal<Object>, Object> replayThreadLocalValues(@NonNull HashMap<ThreadLocal<Object>, Object> captured) {
	final HashMap<ThreadLocal<Object>, Object> backup = new HashMap<ThreadLocal<Object>, Object>();

	for (Map.Entry<ThreadLocal<Object>, Object> entry : captured.entrySet()) {
		final ThreadLocal<Object> threadLocal = entry.getKey();
		backup.put(threadLocal, threadLocal.get());

		final Object value = entry.getValue();
		if (value == threadLocalClearMark) threadLocal.remove();
		else threadLocal.set(value);
	}

	return backup;
}
```



#### TransmittableThreadLocal.Transmitter.restore()

```
// 从 replay(Object)/clear() 恢复备份的 TransmittableThreadLocal 和注册的 ThreadLocal 值。
// 参数: backup – 来自 replay(Object)/clear() 的备份 TransmittableThreadLocal 值
public static void restore(@NonNull Object backup) {
	final Snapshot backupSnapshot = (Snapshot) backup;
	restoreTtlValues(backupSnapshot.ttl2Value);
	restoreThreadLocalValues(backupSnapshot.threadLocal2Value);
}
```

通过代码可知，调用 restore() 本质是恢复 replay() 返回的值。



##### TransmittableThreadLocal.Transmitter.restoreTtlValues()

```
private static void restoreTtlValues(@NonNull HashMap<TransmittableThreadLocal<Object>, Object> backup) {
	// 调用 afterExecute 回调
	doExecuteCallback(false);

	for (final Iterator<TransmittableThreadLocal<Object>> iterator = holder.get().keySet().iterator(); iterator.hasNext(); ) {
		TransmittableThreadLocal<Object> threadLocal = iterator.next();

		// 清除不在 backup 中的 TTL 值
		// 避免恢复后额外的 TTL 值
		if (!backup.containsKey(threadLocal)) {
			iterator.remove();
			threadLocal.superRemove();
		}
	}

	// 恢复 TTL 值
	setTtlValuesTo(backup);
}
```



##### TransmittableThreadLocal.Transmitter.restoreThreadLocalValues()

```
private static void restoreThreadLocalValues(@NonNull HashMap<ThreadLocal<Object>, Object> backup) {
	for (Map.Entry<ThreadLocal<Object>, Object> entry : backup.entrySet()) {
		final ThreadLocal<Object> threadLocal = entry.getKey();
		threadLocal.set(entry.getValue());
	}
}
```



### TransmittableThreadLocal 使用场景

### TransmittableThreadLocal 源码分析
