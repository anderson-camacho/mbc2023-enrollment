import Text "mo:base/Text";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Result "mo:base/Result";

actor class Homework() {

  public type Homework = {
    title : Text;
    description : Text;
    dueDate : Time.Time;
    completed : Bool;
  };

  let homeworkDiary = Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared func addHomework(task : Homework) : async Nat {
    homeworkDiary.add(task);
    return (homeworkDiary.size() - 1);
  };

  // Get a specific homework task by id
  public shared func getHomework(taskId : Nat) : async Result.Result<Homework, Text> {
    if (homeworkDiary.size() <= taskId) {
      return #err "The requested task ID is greater than the size of the daily tasks.";
    };
    let task = homeworkDiary.get(taskId);
    return #ok task;
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(taskId : Nat, newTask : Homework) : async Result.Result<(), Text> {
    if (homeworkDiary.size() <= taskId) {
      return #err "The requested taskId is higher";
    };
    homeworkDiary.put(taskId, newTask);
    return #ok();
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(taskId : Nat) : async Result.Result<(), Text> {
    if (homeworkDiary.size() <= taskId) {
      return #err "The requested taskId is higher";
    };
    var task : Homework = homeworkDiary.get(taskId);
    var markedTask : Homework = {
      title = task.title;
      description = task.description;
      dueDate = task.dueDate;
      completed = true;
    };
    homeworkDiary.put(taskId, markedTask);
    return #ok();
  };

  // Delete a homework task by id
  public shared func deleteHomework(taskId : Nat) : async Result.Result<(), Text> {
    if (homeworkDiary.size() <= taskId) {
      return #err "The requested taskId is higher";
    };
    let x = homeworkDiary.remove(taskId);
    return #ok();
  };

  // Get the list of all homework tasks
  public shared func getAllHomework() : async [Homework] {
    return Buffer.toArray<Homework>(homeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  public shared func getPendingHomework() : async [Homework] {
    var pending = Buffer.clone(homeworkDiary);
    pending.filterEntries(func(_, task) = task.completed == false);
    return Buffer.toArray<Homework>(pending);
  };

  // Search for homework tasks based on a search terms
  public shared func searchHomework(searchTerm : Text) : async [Homework] {
    var search = Buffer.clone(homeworkDiary);
    search.filterEntries(func(_, task) = Text.contains(task.title, #text searchTerm) or Text.contains(task.description, #text searchTerm));
    return Buffer.toArray<Homework>(search);
  };
};
