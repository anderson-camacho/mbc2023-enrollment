import Principal "mo:base/Principal";

// Don't forget to NOT use this actor when deploying to --network IC
// On the IC, you should import actor from "rww3b-zqaaa-aaaam-abioa-cai" and call same method

module {
  public let RemoteActor = actor("rww3b-zqaaa-aaaam-abioa-cai") : actor {
    getAllStudentsPrincipal : shared () -> async [Principal];
  };
}