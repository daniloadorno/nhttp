# nhttp

Native Http

## Usage
Plugin for native requests on android and ios, other platforms using http package

### Example
import 'package:nhttp/nhttp.dart' as nhttp;

Future<nhttp.Response> _getData() async {
    return await nhttp.get("https://jsonplaceholder.typicode.com/albums/1");
}

