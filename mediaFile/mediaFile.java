import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.File;
import java.io.IOException; 
import java.util.ArrayList;
import java.util.List;


import org.apache.http.client.HttpClient;
import org.apache.http.HttpEntity;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;



import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;

public class mediaFile {
	static String URL = "http://localhost:3000/bulk_insert";
	static String USER_NAME = "alice";
	static String PASSWORD = "alice";
	static boolean recursive = true;
	
	static String jsonString = "[";
	static boolean firstEntry = true;
	
	public static void traverse(File parentNode, String leftIndent) {
    	 if (firstEntry) {
	 		firstEntry = false;
		 } else {
		 	jsonString = jsonString + ",";
		 }
		
		String type = (parentNode.isDirectory()) ? "dir" : "file";
		
		// {"name":"<name>","path":"<path>","size":"<size>","type":"<type>"}
		System.out.println(parentNode.getName() + "," + parentNode.getPath() +"," + parentNode.length());
		 jsonString = jsonString + "{\"name\":\"" + parentNode.getName() + "\",\"path\":\"" +
			 parentNode.getPath() + "\",\"size\":\"" + parentNode.length() +
			 "\",\"type\":\"" + type + "\"}";
        if (parentNode.isDirectory()) {
            
 
            // Use left padding to create tree structure in the console output.
            leftIndent += "   ";
 
            File childNodes[] = parentNode.listFiles();
            for (File childNode : childNodes) {
                traverse(childNode, leftIndent);
            }
        }
	}

	public static void main(String[] args) {
		try {
			BufferedReader bufferedReader = new BufferedReader(
            	          new FileReader("config.txt"));
			URL = bufferedReader.readLine();
			USER_NAME = bufferedReader.readLine();
			PASSWORD = bufferedReader.readLine();
			bufferedReader.close();
		} catch(Exception e) {
			System.out.println("Unable to open config.txt");
		}
		
		
		String filePath;
		String file = "";
		String directory = "";
		
		if(args.length == 0) {
			System.out.println("Enter File or Path");
			return;
		}
		
		
		if (args.length >= 1) {
			filePath = args[0];
			
			Matcher fileMatcher = Pattern.compile("([\\w\\-]+(\\.\\w+)+)").matcher(filePath);
			Matcher dirMatcher = Pattern.compile("(([\\w\\-]+\\/)+)").matcher(filePath);
		
			if(dirMatcher.find()) {
				directory += "/"+dirMatcher.group(0);
			}
			if(fileMatcher.find()) {
				file = fileMatcher.group(0);
			}
			
			
		} else {
			file = null;
		}
		if (file == null) {
			file = "";
		}
	
		
		//System.out.println("Dir: " + directory);
		//System.out.println("File: " + file);
		
		if(!file.equals("") && !directory.substring(directory.length()-1,directory.length()).equals("/")) {
			directory = directory + "/";
		}
		
		String searchPath = directory + file;
		
		
		//System.out.println(searchPath);
		
		
		File inputFolder = new File(searchPath);
        traverse(inputFolder, "");
		jsonString = jsonString + "]";
		System.out.println(jsonString);
		System.out.println("");
		
		CloseableHttpResponse response = null;
		try {
			CloseableHttpClient client = HttpClients.createDefault();
		
			HttpPost httpPost = new HttpPost(URL);
			List <NameValuePair> nvps = new ArrayList <NameValuePair>();
			//nvps.add(new BasicNameValuePair("username", "vip"));
			//nvps.add(new BasicNameValuePair("password", "secret"));
			nvps.add(new BasicNameValuePair("user",USER_NAME));
			nvps.add(new BasicNameValuePair("password", PASSWORD));
			nvps.add(new BasicNameValuePair("data", jsonString));
		
			httpPost.setEntity(new UrlEncodedFormEntity(nvps));

			//CloseableHttpResponse response2 = httpclient.execute(httpPost);
			response = client.execute(httpPost);

    		HttpEntity entity2 = response.getEntity();
    		int status = response.getStatusLine().getStatusCode();
			
			if(status == 204) {
				System.out.println("Dagrs Added");
			} else if(status == 401) {
				System.out.println("Incorect Name or Password");
			} else {
				System.out.println("Error");
			}
			
    		EntityUtils.consume(entity2);
		} catch(Exception e) {
			System.out.println("failure connecting to Host");
		}
		
		
	}
}













