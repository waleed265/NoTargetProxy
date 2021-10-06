package com.apigee.mgmtapi.sdk.client;

import java.nio.charset.Charset;

import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.HttpClient;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.log4j.Logger;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.security.crypto.codec.Base64;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import com.apigee.edge.config.utils.ServerProfile;
import com.apigee.mgmtapi.sdk.model.AccessToken;
import com.google.gson.Gson;

public class MgmtAPIClient {
	
	private static final Logger logger = Logger.getLogger(MgmtAPIClient.class);

	private RestTemplate restTemplate;
	
	public MgmtAPIClient(ServerProfile profile) {
		if(profile.getHasProxy()) {
			
			HttpClientBuilder clientBuilder = HttpClientBuilder.create();
			HttpHost proxy = new HttpHost(profile.getProxyServer(), profile.getProxyPort());
			
			if(profile.getProxyUsername()!=null && !profile.getProxyUsername().equalsIgnoreCase("")
					&& profile.getProxyPassword()!=null && !profile.getProxyPassword().equalsIgnoreCase("")) {
				CredentialsProvider credsProvider = new BasicCredentialsProvider();
				credsProvider.setCredentials( 
				        new AuthScope(profile.getProxyServer(), profile.getProxyPort()), 
				        new UsernamePasswordCredentials(profile.getProxyUsername(), profile.getProxyPassword())
				    );
				clientBuilder.setDefaultCredentialsProvider(credsProvider).disableCookieManagement();
			}
			
		    clientBuilder.setProxy(proxy);
		    
		    HttpClient httpClient = clientBuilder.build();
		    HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory();
		    factory.setHttpClient(httpClient);
		    
		    restTemplate = new RestTemplate(factory);
		}
		/*if(profile.getHasProxy()) {
			SimpleClientHttpRequestFactory clientHttpReq = new SimpleClientHttpRequestFactory();
			Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress(profile.getProxyServer(), profile.getProxyPort()));
			clientHttpReq.setProxy(proxy);
			restTemplate = new RestTemplate(clientHttpReq);
		}*/
		else {
			restTemplate = new RestTemplate();
		}
	}

	/**
	 * To get the Access Token Management URL, client_id and client_secret needs
	 * to be passed through a config file whose full path is passed as system
	 * property like -DconfigFile.path="/to/dir/config.properties"
	 * 
	 * @param username
	 * @param password
	 * @return
	 * @throws Exception
	 */
	/*public AccessToken getAccessToken(String username, String password) throws Exception {
		Environment env = this.getConfigProperties();
		if (env == null) {
			logger.error("Config file missing");
			throw new Exception("Config file missing");
		}
		return getAccessToken(env.getProperty("mgmt.login.url"), env.getProperty("mgmt.login.client.id"),
				env.getProperty("mgmt.login.client.secret"), username, password);
	}*/
	
	/**
	 * To get the Access Token Management URL, client_id and client_secret needs
	 * to be passed through a config file whose full path is passed as system
	 * property like -DconfigFile.path="/to/dir/config.properties"
	 * 
	 * @param username
	 * @param password
	 * @param mfa
	 * @return
	 * @throws Exception
	 */
	/*public AccessToken getAccessToken(String username, String password, String mfa) throws Exception {
		Environment env = this.getConfigProperties();
		if (env == null) {
			logger.error("Config file missing");
			throw new Exception("Config file missing");
		}
		if (mfa == null || mfa.equals("")) {
			logger.error("mfa cannot be empty");
			throw new Exception("mfa cannot be empty");
		}
		return getAccessToken(env.getProperty("mgmt.login.mfa.url")+mfa, env.getProperty("mgmt.login.client.id"),
				env.getProperty("mgmt.login.client.secret"), username, password);
	}*/


	/**
	 * To get Access Token
	 * @param url
	 * @param clientId
	 * @param client_secret
	 * @param username
	 * @param password
	 * @param mfa
	 * @return
	 * @throws Exception
	 */
	public AccessToken getAccessToken(String url, String clientId, String client_secret, String username,
			String password, String mfa) throws Exception {
		return getAccessToken(url+"?mfa_token="+mfa, clientId, client_secret, username, password);
	}
	
	/**
	 * To get the Access Token
	 * 
	 * @param url
	 * @param clientId
	 * @param client_secret
	 * @param username
	 * @param password
	 * @return
	 * @throws Exception
	 */
	public AccessToken getAccessToken(String url, String clientId, String client_secret, String username,
			String password) throws Exception {
		//RestTemplate restTemplate = new RestTemplate();
		HttpHeaders headers = new HttpHeaders();
		AccessToken token = new AccessToken();
		ResponseEntity<String> result = null;
		try {
			headers.add("Authorization", "Basic "
					+ new String(Base64.encode((clientId + ":" + client_secret).getBytes()), Charset.forName("UTF-8")));
			headers.add("Content-Type", "application/x-www-form-urlencoded");
			MultiValueMap<String, String> map = new LinkedMultiValueMap<String, String>();
			map.add("username", username);
			map.add("password", password);
			map.add("grant_type", "password");
			HttpEntity<Object> request = new HttpEntity<Object>(map, headers);
			result = restTemplate.postForEntity(url, request, String.class);
			if (result.getStatusCode().equals(HttpStatus.OK)) {
				Gson gson = new Gson();
				token = gson.fromJson(result.getBody(), AccessToken.class);

			}
		} catch (Exception e) {
			logger.error(e.getMessage());
			throw e;
		}
		return token;

	}
	
	/**
	 * To get the Access Token from Refresh Token
	 * 
	 * @param url
	 * @param clientId
	 * @param client_secret
	 * @param username
	 * @param password
	 * @return
	 * @throws Exception
	 */
	public AccessToken getAccessTokenFromRefreshToken(String url, String clientId, String client_secret, String refreshToken) throws Exception {
		//RestTemplate restTemplate = new RestTemplate();
		HttpHeaders headers = new HttpHeaders();
		AccessToken token = new AccessToken();
		ResponseEntity<String> result = null;
		try {
			headers.add("Authorization", "Basic "
					+ new String(Base64.encode((clientId + ":" + client_secret).getBytes()), Charset.forName("UTF-8")));
			headers.add("Content-Type", "application/x-www-form-urlencoded");
			MultiValueMap<String, String> map = new LinkedMultiValueMap<String, String>();
			map.add("refresh_token", refreshToken);
			map.add("grant_type", "refresh_token");
			HttpEntity<Object> request = new HttpEntity<Object>(map, headers);
			result = restTemplate.postForEntity(url, request, String.class);
			if (result.getStatusCode().equals(HttpStatus.OK)) {
				Gson gson = new Gson();
				token = gson.fromJson(result.getBody(), AccessToken.class);

			}
		} catch (Exception e) {
			logger.error("Refresh Token could be invalid or expired: "+e.getMessage());
			throw e;
		}
		return token;

	}

	/**
	 * Fetch the properties from the property file passed as system argument (-DconfigFile.path)
	 * @return
	 */
	/*public Environment getConfigProperties() {
		AbstractApplicationContext context;
		FileService service = null;
		try {
			if (System.getProperty("configFile.path") != null
					&& !System.getProperty("configFile.path").equalsIgnoreCase("")) {
				context = new AnnotationConfigApplicationContext(AppConfig.class);
				service = (FileService) context.getBean("fileService");
			} else
				return null;
		} catch (Exception e) {
			logger.error(e.getMessage());
		}
		return service.getEnvironment();
	}*/
}
