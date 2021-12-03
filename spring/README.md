# 基于 Spring 构建架构

## 认证相关 Spring Security

### 常用的辅助工具类
- SecurityContextHolder/ReactiveSecurityContextHolder 获取登录成功后的用户认证信息

### 实现 UserDetailsService 接口
自定义自己的登录认证机制，此处通常用于实现通过登录账号查的用户表，获取授权信息。可加入RBAC思想

### 实现 UserDetails 接口
自定义自己的用户信息

示例：
```java

/**
 * Security用户
 * 
 *  
 */

public class CustomUserDetails implements UserDetails {
	/**
	 * 用户权限
	 */
	private Collection<? extends GrantedAuthority> authorities;
	
	/**
	 * 用户名
	 */
	private String username;
	
	/**
	 * 密码
	 */
	private String password;
	
	/**
	 * 账号未过期
	 */
	private boolean accountNonExpired;
	
	/**
	 * 账号未锁定
	 */
	private boolean accountNonLocked;
	
	/**
	 * 信用未过期
	 */
	private boolean credentialsNonExpired;
	
	/**
	 * 是否可用
	 */
	private boolean enabled;
	
	
	
	public CustomUserDetails(Collection<? extends GrantedAuthority> authorities, String username, String password,
			boolean enabled) {
		super();
		this.authorities = authorities;
		this.username = username;
		this.password = password;
		this.enabled = enabled;
		this.credentialsNonExpired = true;
		this.accountNonExpired = true;
		this.accountNonLocked = true;
	}

	public CustomUserDetails(Collection<? extends GrantedAuthority> authorities, String username, String password,
			boolean accountNonExpired, boolean accountNonLocked, boolean credentialsNonExpired, boolean enabled) {
		super();
		this.authorities = authorities;
		this.username = username;
		this.password = password;
		this.accountNonExpired = accountNonExpired;
		this.accountNonLocked = accountNonLocked;
		this.credentialsNonExpired = credentialsNonExpired;
		this.enabled = enabled;
	}

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return authorities;
	}

	@Override
	public String getPassword() {
		return password;
	}

	@Override
	public String getUsername() {
		return username;
	}

	@Override
	public boolean isAccountNonExpired() {
		return accountNonExpired;
	}


	@Override
	public boolean isAccountNonLocked() {
		return accountNonLocked;
	}

	@Override
	public boolean isCredentialsNonExpired() {
		return credentialsNonExpired;
	}

	@Override
	public boolean isEnabled() {
		return enabled;
	}
	
	private static final long serialVersionUID = 2166204891456417450L;
}
```

### 继承 SimpleUrlAuthenticationFailureHandler
校验失败处理逻辑

### 继承 SimpleUrlAuthenticationSuccessHandler
登录成功后的逻辑处理

### 实现 AccessDeniedHandler 接口
访问被拒绝后执行的逻辑
示例:
```java

/**
 * 访问被拒绝后执行的逻辑
 */
public class CustomAccessDeniedHandler implements AccessDeniedHandler {
    private static final Logger LOGGER = LoggerFactory.getLogger(CustomAccessDeniedHandler.class);
    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException e) throws IOException, ServletException {
        LOGGER.info("Access denied......：" + request.getServletPath(), e);
        ExceptionCaptureAsResponse.responseMessage(ResultObject.NO_PRIVILEGE,"没有权限");
    }

}
```

### 继承 LoginUrlAuthenticationEntryPoint
自定义身份认证

### 继承 AbstractAuthenticationProcessingFilter 实现自定义过滤器
可以用实现 手机/验证码（图形验证码）登录

## Spring MVC
### 常用的辅助工具类
- RequestContextHolder 全局获取当前的 request 和 response

### HandlerInterceptor
#### 防重复提交
可在 `preHandle` 方法中添加防重复提交的逻辑，将防重复提交的key存放到redis，设置一定的超时时间，一般是结合自定义注解使用（如： @NoRepeatSubmit），
key的常见的生成方式有:

- 粗粒度：key 直接基于 `sessionId + url` 
- 细粒度：key 基于 `sessionId + url + 请求参数MD5值` ，此方式的问题在于请求参数可能包含流数据，且获取参数值MD5值耗时比较大

示例:
```java
/**
 *
 * 防止重复提交
 *
 */
@Target(ElementType.METHOD) // 作用到方法上
@Retention(RetentionPolicy.RUNTIME) // 运行时有效
public @interface NoRepeatSubmit { 
    long time() default 2l; // 超时时间
    TimeUnit unit() default TimeUnit.MILLISECONDS; // 时间单位
}
```

#### 数据权限
接口或者按钮权限等粒度控制

### rest 接口返回对象，字段映射翻译
