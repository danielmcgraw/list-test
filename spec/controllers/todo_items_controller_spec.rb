require 'spec_helper'

describe TodoItemsController do
  let(:todo_item) { TodoItem.create(content: "Get milk and eggs") }
  let(:todo_list) { TodoList.create(title: "My Title", description: "This is my test list") }

  before() do
    todo_list.todo_items << todo_item
  end

  describe "#index" do
    it 'should set the @todo_list controller based off the todo_list_id' do
      get :index, todo_list_id: todo_list.id

      expect(assigns(:todo_list)).to eq(todo_list)
    end

    it 'should redirect to new_todo_list_path if todo_list is not found' do
      get :index, todo_list_id: todo_list.id + 1
      expect(response).to redirect_to(new_todo_list_path)
    end

    it 'should render the index template' do
      get :index, todo_list_id: todo_list.id
      expect(response).to render_template(:index)
    end
  end

  describe "#new" do
    it 'should render the new template' do
      get :new, todo_list_id: todo_list.id
      expect(response).to render_template(:new)
    end

    it 'should redirect to new_todo_list_path if todo_list is not found' do
      get :new, todo_list_id: todo_list.id + 1
      expect(response).to redirect_to(new_todo_list_path)
    end
  end

  describe "#edit" do
    it 'should render the edit template' do
      get :edit, todo_list_id: todo_list.id, id: todo_item.id
      expect(response).to render_template(:edit)
    end

    it 'should redirect to new_todo_list_path if todo_list is not found' do
      get :edit, todo_list_id: todo_list.id + 1, id: todo_item.id
      expect(response).to redirect_to(new_todo_list_path)
    end
  end

  describe "#update" do
    it 'should redirect to the index' do
      put :update, todo_list_id: todo_list.id, id: todo_item.id, todo_item: {content: todo_item.content}
      expect(response).to redirect_to(todo_list_todo_items_path)
    end

    it 'should redirect to new_todo_list_path if todo_list is not found' do
      put :update, todo_list_id: todo_list.id + 1, id: todo_item.id
      expect(response).to redirect_to(new_todo_list_path)
    end

    it 'should update the specified item' do
      put :update, todo_list_id: todo_list.id, id: todo_item.id, todo_item: {content: "New content"}
      expect(todo_item.reload.content).to eq "New content"
    end
  end

  describe "#create" do
    it 'should create a new todo item for the specified list' do
      post :create, todo_list_id: todo_list.id, todo_item: { content: "This is my new item" }
      expect(todo_list.todo_items.length).to eq(2)
      expect(todo_list.todo_items[1].content).to eq("This is my new item")
    end

    it 'should redirect to new_todo_list_path if todo_list is not found' do
      post :create, todo_list_id: todo_list.id + 1, todo_item: { content: "This is my new item" }
      expect(response).to redirect_to(new_todo_list_path)
    end
  end

  describe "#delete" do
    it 'should delete the specific item' do
      expect{
        delete :destroy, :todo_list_id => todo_list.id, :id => todo_list.todo_items[0].id
      }.to change(TodoItem, :count).by(-1)
    end

    it 'should redirect to the root url' do
      delete :destroy, :todo_list_id => todo_list.id, :id => todo_list.todo_items[0].id
      response.body.should include("window.location = '/'")
    end

    it 'should have a deleted flash message' do
      new_todo_list = TodoList.create(title: "My New List", description: "This is my test list")
      new_todo_list.todo_items.push(TodoItem.create(content: "Get on up"))
      new_todo_list.todo_items.push(TodoItem.create(content: "Also get funky"))

      delete :destroy, :todo_list_id => new_todo_list.id, :id => new_todo_list.todo_items[0].id
      expect(flash[:success]).to eq "Your todo item was successfully removed."
    end

    it 'should have a special flash message when deleting the last item in the list' do
      delete :destroy, :todo_list_id => todo_list.id, :id => todo_list.todo_items[0].id
      expect(flash[:success]).to eq "The last todo item was successfully removed and your todo list was deleted."
    end

    it 'should have a special flash message and redirect to the todo items path if deleting throws an error' do
      delete :destroy, :todo_list_id => 12345, :id => 67890
      response.body.should include("window.location = '/todo_lists/12345/todo_items'")
      expect(flash[:error]).to eq "Sorry, there was a problem deleting the todo item."
    end
  end
end
