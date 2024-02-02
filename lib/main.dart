import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const productsQl = """
  query products{
    products(first: 10) {
     edges {
       node {
         id
         title
         description
         thumbnail{
            url
         }
       }
     }
    }
  }
""";

const allPosts = """
  query GetPosts(\$limit: Int!){
    user(id: 1){
      posts(limit: \$limit) {
        data {
          id
          title
        } 
      }
    }
  }
""";

void main() async {
  final HttpLink httpLink = HttpLink(
    // 'https://demo.saleor.io/graphql/',
    'https://graphqlzero.almansi.me/api',
  );

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    ),
  );

  var app = GraphQLProvider(client: client, child: MainApp());

  runApp(app);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Query<String>(
            options:
                QueryOptions(document: gql(allPosts), variables: {'limit': 5}),
            builder: (QueryResult result, {fetchMore, refetch}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return CircularProgressIndicator();
              }

              // final List repositories = result.data?['posts']['data'];
              final List repositories = result.data?['user']['posts']['data'];

              return Column(
                children: [
                  Container(
                      child: ElevatedButton(
                    child: Text("Reload"),
                    onPressed: () {
                      refetch!();
                    },
                  )),
                  Expanded(
                    child: ListView.builder(
                      itemCount: repositories.length,
                      itemBuilder: (context, index) {
                        final repository = repositories[index];

                        return ListTile(
                          title: Text(repository['title']),
                          // subtitle: Text(repository['body']),
                        );
                      },
                    ),
                  ),
                ],
              );

              // print(repositories.toString());
              // return Text(repositories.toString());
            }),
      ),
    );
  }
}
