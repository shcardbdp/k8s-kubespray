
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;



@SpringBootApplication
public class JdbcClient {

	public static void main(String[] args) throws SQLException, IOException {
		SpringApplication.run(JdbcClientApplication.class, args);

		// java -jar JdbcClient-1.0.0.jar <type:oracle/hive> <sql> <filename>
		String type = args[0];
		String sql = args[1];
		String filename = args[2];
		System.out.println("[JdbcClient] type : " + type);
		System.out.println("[JdbcClient] sql : " + sql);
		System.out.println("[JdbcClient] filename : " + filename);
		
		Properties prop =new Properties();
		InputStream input = null;
		String driverName = null;
		String url = null;
		String username = null;
		String password = null;
		try {
			input = new FileInputStream("/etc/datalake/datalake.properties");
			prop.load(input);
			switch (type) {
			case "hive":
				driverName = prop.getProperty("hive.datasource.driver");
				url = prop.getProperty("hive.datasource.url");
				username = prop.getProperty("hive.datasource.username");
				password = prop.getProperty("hive.datasource.password");
				break;
			case "oracle":
				driverName = prop.getProperty("oracle.datasource.driver");
				url = prop.getProperty("oracle.datasource.url");
				username = prop.getProperty("oracle.datasource.username");
				password = prop.getProperty("oracle.datasource.password");
				break;

			default:
				break;
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			input.close();
		}
		
		System.out.println("[JdbcClient] dirver : " + driverName);
		System.out.println("[JdbcClient] url : " + url);
		System.out.println("[JdbcClient] username : " + username);
		System.out.println("[JdbcClient] password : " + password);

		try {
			Class.forName(driverName);
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		Connection con = DriverManager.getConnection(url, username, password);
		Statement stmt = con.createStatement();
		System.out.println("[JdbcClient] Running : " + sql);
		
		ResultSet result = stmt.executeQuery(sql);
		int ncols = result.getMetaData().getColumnCount();
		System.out.println("[JdbcClient] Column Count : " + ncols);
		
		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(new File("./"+filename), false);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		Writer out = null;
		try {
			out = new OutputStreamWriter(new BufferedOutputStream(fos), "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		for (int j = 1; j < (ncols + 1); j++) {
			try {
				out.append(result.getMetaData().getColumnName(j));
			} catch (IOException e) {
				e.printStackTrace();
			}
			if (j < ncols)
				out.append(",");
			else
				out.append("\r\n");
		}
		int m = 1;
		while (result.next()) {
			for (int k = 1; k < (ncols + 1); k++) {
				out.append(result.getString(k));
				if (k < ncols)
					out.append(",");
				else
					out.append("\r\n");
			}
			m++;
		}
		out.close();
		fos.close();
		result.close();
		stmt.close();
		con.close();
		System.out.println("[JdbcClient] The End");
	}
}
